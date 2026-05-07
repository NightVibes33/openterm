import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";

type ChatMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

type ProxyRequest = {
  feature_code?: string;
  model?: string;
  messages?: ChatMessage[];
  estimated_tokens?: number;
  device_id?: string | null;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const openAIKey = Deno.env.get("OPENAI_API_KEY");

  if (!supabaseUrl || !supabaseAnonKey || !openAIKey) {
    return json({ error: "server_not_configured" }, 500);
  }

  const authorization = request.headers.get("Authorization") ?? "";
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authorization } },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return json({ error: "unauthorized" }, 401);
  }

  let body: ProxyRequest;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const featureCode = body.feature_code ?? "assistant";
  const model = body.model ?? "gpt-4.1-mini";
  const messages = body.messages ?? [];
  const estimatedTokens = Math.max(0, body.estimated_tokens ?? estimateTokens(messages));

  if (!messages.length || messages.some((message) => !message.content?.trim())) {
    return json({ error: "messages_required" }, 400);
  }

  const { data: allowed, error: limitError } = await supabase.rpc("can_consume_ai_request", {
    p_user_id: userData.user.id,
    p_feature_code: featureCode,
    p_estimated_tokens: estimatedTokens,
  });

  if (limitError) {
    return json({ error: "rate_limit_check_failed", detail: limitError.message }, 500);
  }

  if (!allowed) {
    return json({ error: "rate_limit_exceeded" }, 429);
  }

  const upstream = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${openAIKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ model, messages }),
  });

  const upstreamText = await upstream.text();
  let upstreamJson: Record<string, unknown> = {};
  try {
    upstreamJson = JSON.parse(upstreamText);
  } catch {
    upstreamJson = { raw: upstreamText };
  }

  const usage = upstreamJson.usage as { prompt_tokens?: number; completion_tokens?: number } | undefined;
  await supabase.rpc("record_ai_usage_limited", {
    p_user_id: userData.user.id,
    p_device_id: body.device_id ?? null,
    p_feature_code: featureCode,
    p_provider: "openai",
    p_model: model,
    p_prompt_tokens: usage?.prompt_tokens ?? estimatedTokens,
    p_completion_tokens: usage?.completion_tokens ?? 0,
  });

  return new Response(JSON.stringify(upstreamJson), {
    status: upstream.status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
});

function estimateTokens(messages: ChatMessage[]): number {
  const chars = messages.reduce((count, message) => count + message.content.length, 0);
  return Math.ceil(chars / 4);
}

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
