{{/* 
  This helper script processes the labels by iterating over each key-value pair.
  If the key is "app.image/new-version", it checks if the value starts with a 
  non-alphanumeric character and removes it. Finally, it outputs the key-value 
  pair with the value quoted.

  Steps:
  1. Loop through each label (key-value pair).
  2. Convert the value to a string to ensure consistent handling.
  3. Check if the key is "app.image/new-version" and apply special logic.
  4. Remove non-alphanumeric characters from the beginning of the value (if needed).
  5. Print the key and the processed value with the value quoted.
*/}}

{{- define "removeSpecialCharacterPrefix" -}}
  {{- range $key, $value := . }}
    {{- $processedValue := $value | toString }}
    {{- if eq $key "app.image/new-version" }}
      {{- if regexMatch "^[^a-zA-Z0-9]" $processedValue }}
        {{- $processedValue = substr 1 -1 $processedValue }}
      {{- end }}
    {{- end }}
    {{ $key }}: {{ $processedValue | quote }}
  {{- end }}
{{- end -}}