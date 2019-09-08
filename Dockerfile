#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-nanoserver-1803 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:2.1-nanoserver-1803 AS build
WORKDIR /src
COPY ["src/projectApi.Api/projectApi.Api.csproj", "src/projectApi.Api/"]
COPY ["src/projectApi.Common/projectApi.Common.csproj", "src/projectApi.Common/"]
COPY ["src/projectApi.Service/projectApi.Service.csproj", "src/projectApi.Service/"]
RUN dotnet restore "src/projectApi.Api/projectApi.Api.csproj"
RUN dotnet restore "src/projectApi.Common/projectApi.Common.csproj"
RUN dotnet restore "src/projectApi.Service/projectApi.Service.csproj"
COPY . .
WORKDIR "/src/src/projectApi.Api"
RUN dotnet build "projectApi.Api.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "projectApi.Api.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "projectApi.Api.dll"]