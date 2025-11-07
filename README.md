# Hello MCP Server

A Spring Boot application that implements a Model Context Protocol (MCP) server providing simple greeting tools.

## Overview

This project demonstrates how to build an MCP server using Spring Boot and Spring AI. It provides a simple "hello-tool" that can be called by MCP clients to get greeting messages.

## Technologies Used

- **Java**: 25
- **Spring Boot**: 3.5.7
- **Spring AI**: 1.1.0-M4 (with MCP server support)
- **Gradle**: 8.14.3
- **Build Tool**: Gradle Wrapper

## Features

- MCP server implementation with Spring AI
- Simple greeting tool (`hello-tool`)
- Configurable MCP server settings
- RESTful web endpoints
- Comprehensive logging

## Project Structure

```
src/main/java/com/shan/hello_mcp/
├── HelloMcpApplication.java    # Main Spring Boot application
└── HelloTools.java             # MCP tools implementation
```

## Getting Started

### Prerequisites

- Java 25 or higher
- Git

### Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd hello-mcp
   ```

2. **Build the project:**
   ```bash
   ./gradlew build
   ```

3. **Run the application:**
   ```bash
   ./gradlew bootRun
   ```

The application will start on the default port (8080) and the MCP server will be available for client connections.

## Configuration

The MCP server is configured in `application.properties`:

```properties
spring.application.name=hello-mcp
spring.ai.mcp.server.name=HelloMCPServer
spring.ai.mcp.server.description=A simple MCP server application
spring.ai.mcp.server.version=1.0.0
spring.ai.mcp.server.author=Shan
spring.ai.mcp.server.protocol=streamable
spring.ai.mcp.server.stdio=false
spring.ai.mcp.server.type=sync
```

## Available Tools

### hello-tool

- **Name**: `hello-tool`
- **Description**: A tool that returns a hello message from the MCP server
- **Response**: Returns "Hello from MCP server!" message

## Usage Example

When connected to an MCP client, you can call the `hello-tool` to receive a greeting message. The tool will log the call and return the greeting response.

## Development

### Running Tests

```bash
./gradlew test
```

### Building for Production

```bash
./gradlew bootJar
```

The executable JAR will be created in `build/libs/`.

## Dependencies

Key dependencies include:
- `spring-boot-starter-web`: Web framework support
- `spring-ai-starter-mcp-server-webmvc`: MCP server implementation
- `spring-boot-starter-test`: Testing framework

## Author

Shan

## Version

0.0.1-SNAPSHOT

