# Final stage
FROM debian:bookworm-slim
ENV TZ="America/Chicago"
WORKDIR /app
COPY build/* .
RUN chmod +x spatial-audio-demo-2d.sh spatial-audio-demo-2d.x86_64
ENV PORT=8910
EXPOSE 8910/udp
CMD ["/app/spatial-audio-demo-2d.sh", "--server", "--headless"]
