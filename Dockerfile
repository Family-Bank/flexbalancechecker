# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

# Expose ports
EXPOSE 8080
EXPOSE 8081

# Copy certificate into container
COPY ./certs/balancefetcher.pfx /app/cert/balancefetcher.pfx

# Accept PFX password as build arg
ARG CERT_PASSWORD

# Environment variables
ENV ASPNETCORE_URLS=http://+:8080;https://+:8081
ENV DOTNET_CERT_PATH=/app/cert/balancefetcher.pfx
ENV DOTNET_CERT_PASSWORD=$CERT_PASSWORD
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Flex_Balance_Fetcher.dll"]
