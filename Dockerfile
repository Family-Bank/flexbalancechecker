# Stage 1: Build and publish the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies first (cache layer)
COPY Flex_Balance_Fetcher.csproj ./
RUN dotnet restore Flex_Balance_Fetcher.csproj

# Copy the rest of the source code
COPY . .

# Build and publish the app
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/publish .

# Expose HTTP and HTTPS ports
EXPOSE 8080
EXPOSE 8081

# Copy PFX certificate into container
COPY ./certs/balancefetcher.pfx /app/cert/balancefetcher.pfx

# Accept PFX password as build arg
ARG CERT_PASSWORD

# Environment variables for Kestrel
ENV ASPNETCORE_URLS=http://+:8080;https://+:8081
ENV DOTNET_CERT_PATH=/app/cert/balancefetcher.pfx
ENV DOTNET_CERT_PASSWORD=$CERT_PASSWORD
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the application
ENTRYPOINT ["dotnet", "Flex_Balance_Fetcher.dll"]
