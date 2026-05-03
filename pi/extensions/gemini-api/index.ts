import type { ExtensionAPI, ProviderModelConfig } from "@mariozechner/pi-coding-agent";

const PROVIDER_ID = "gemini-api";
const PROVIDER_NAME = "Gemini API";
const BASE_URL = "https://generativelanguage.googleapis.com/v1beta";

function resolveApiKey(): string {
	const key = process.env.GEMINI_API_KEY?.trim() || process.env.GOOGLE_API_KEY?.trim();
	if (!key) {
		throw new Error("Missing GEMINI_API_KEY or GOOGLE_API_KEY.");
	}
	return key;
}

function geminiModels(): ProviderModelConfig[] {
	return [
		{
			id: "gemini-2.5-flash",
			name: "Gemini 2.5 Flash",
			reasoning: true,
			input: ["text", "image"],
			cost: { input: 0.3, output: 2.5, cacheRead: 0.03, cacheWrite: 0 },
			contextWindow: 1048576,
			maxTokens: 65536,
		},
		{
			id: "gemini-2.5-pro",
			name: "Gemini 2.5 Pro",
			reasoning: true,
			input: ["text", "image"],
			cost: { input: 1.25, output: 10, cacheRead: 0.125, cacheWrite: 0 },
			contextWindow: 1048576,
			maxTokens: 65536,
		},
		{
			id: "gemini-3-flash-preview",
			name: "Gemini 3 Flash Preview",
			reasoning: true,
			input: ["text", "image"],
			cost: { input: 0.5, output: 3, cacheRead: 0.05, cacheWrite: 0 },
			contextWindow: 1048576,
			maxTokens: 65536,
		},
		{
			id: "gemini-3-pro-preview",
			name: "Gemini 3 Pro Preview",
			reasoning: true,
			input: ["text", "image"],
			cost: { input: 2, output: 12, cacheRead: 0.2, cacheWrite: 0 },
			contextWindow: 1000000,
			maxTokens: 64000,
		},
	];
}

export default function (pi: ExtensionAPI) {
	const register = () => {
		pi.registerProvider(PROVIDER_ID, {
			name: PROVIDER_NAME,
			baseUrl: BASE_URL,
			apiKey: resolveApiKey(),
			api: "google-generative-ai",
			models: geminiModels(),
		} as any);
	};

	register();

	pi.registerCommand("geminiApi.refreshModels", {
		description: "Reload the Gemini API provider",
		handler: async () => {
			pi.unregisterProvider(PROVIDER_ID);
			register();
		},
	});

	return {
		deactivate: async () => {
			try {
				pi.unregisterProvider(PROVIDER_ID);
			} catch {
				// ignore
			}
		},
	};
}
