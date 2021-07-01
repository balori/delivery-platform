{{- define "deploy-tracker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "deploy-tracker.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "deploy-tracker.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "deploy-tracker.labels" -}}
app.kubernetes.io/name: {{ include "deploy-tracker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{- define "deploy-tracker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deploy-tracker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "deploy-tracker.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
