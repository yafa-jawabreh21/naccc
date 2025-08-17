# Frontend Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./ 2>/dev/null || true
RUN npm i
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
# serve via vite preview
ENV PORT=4173
EXPOSE 4173
CMD ["npm", "run", "preview"]
