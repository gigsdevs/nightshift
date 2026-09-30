FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY nightshift-source.zip /tmp/nightshift-source.zip
RUN unzip -q /tmp/nightshift-source.zip -d /app && rm /tmp/nightshift-source.zip
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
ARG NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=$NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
ENV NEXT_TELEMETRY_DISABLED=$NEXT_TELEMETRY_DISABLED
RUN corepack enable && corepack prepare pnpm@11.25.0 --activate && pnpm install --frozen-lockfile && pnpm build
ENV NODE_ENV=production
EXPOSE 3000
CMD ["pnpm","start"]
