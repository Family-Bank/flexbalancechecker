# Stage 1: Build and publish the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy only the project file first (improves build caching)
COPY Flex_Balance_Fetcher.csproj ./

# Restore dependencies
RUN dotnet restore Flex_Balance_Fetcher.csproj

# Copy the rest of the source code
COPY . .

# Build and publish in a single layer (smaller, faster)
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime image (Debian-based for Oracle compatibility)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/publish .

# Expose ports
EXPOSE 8080
EXPOSE 8081

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the app
ENTRYPOINT ["dotnet", "Flex_Balance_Fetcher.dll"]
