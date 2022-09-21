
{{/*
Alibabacloud log service trace zipkin receiver configuration
*/}}
{{ define "aliyun-opentelemetry-collector.receiver" }}
endpoint: {{ .Values.collectorReceiver.endpoint }}
{{ end }}


{{/*
Alibabacloud log service trace exporter configuration
*/}}
{{ define "aliyun-opentelemetry-collector.exporter" }}
endpoint: {{ .Values.collectorExporter.endpoint }}
project: {{ .Values.collectorExporter.project }}
logstore: {{ .Values.collectorExporter.logstore }}
ecs_ram_role: {{ .Values.collectorExporter.ecs_ram_role }}
{{ end }}

{{/*
Alibabacloud log service trace collector image
*/}}
{{ define "aliyun-opentelemetry-collector.image" }}
endpoint: {{ .Values.collectorExporter.endpoint }}
{{ end }}