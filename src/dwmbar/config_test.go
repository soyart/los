package main

import (
	"encoding/json"
	"testing"
	"time"
)

func TestDurationUnmarshalJSON(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected time.Duration
		wantErr  bool
	}{
		// String duration formats
		{name: "1 second string", input: `"1s"`, expected: 1 * time.Second},
		{name: "500ms string", input: `"500ms"`, expected: 500 * time.Millisecond},
		{name: "5 minutes string", input: `"5m"`, expected: 5 * time.Minute},
		{name: "200ms string", input: `"200ms"`, expected: 200 * time.Millisecond},
		{name: "1h30m string", input: `"1h30m"`, expected: 90 * time.Minute},

		// Numeric formats (interpreted as seconds)
		{name: "1 second number", input: `1`, expected: 1 * time.Second},
		{name: "5 seconds number", input: `5`, expected: 5 * time.Second},
		{name: "0.5 seconds number", input: `0.5`, expected: 500 * time.Millisecond},
		{name: "0.2 seconds number", input: `0.2`, expected: 200 * time.Millisecond},
		{name: "0 seconds number", input: `0`, expected: 0},

		// Error cases
		{name: "invalid string", input: `"invalid"`, wantErr: true},
		{name: "boolean", input: `true`, wantErr: true},
		{name: "null", input: `null`, wantErr: true},
		{name: "array", input: `[1,2,3]`, wantErr: true},
		{name: "object", input: `{"a":1}`, wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var d duration
			err := json.Unmarshal([]byte(tt.input), &d)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error for input %s, got none", tt.input)
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error for input %s: %v", tt.input, err)
				return
			}

			if d.Duration() != tt.expected {
				t.Errorf("got %v, expected %v", d.Duration(), tt.expected)
			}
		})
	}
}

func TestDurationInStruct(t *testing.T) {
	type testConfig struct {
		Interval duration `json:"interval"`
	}

	tests := []struct {
		name     string
		input    string
		expected time.Duration
	}{
		{
			name:     "string in struct",
			input:    `{"interval": "1s"}`,
			expected: 1 * time.Second,
		},
		{
			name:     "number in struct",
			input:    `{"interval": 5}`,
			expected: 5 * time.Second,
		},
		{
			name:     "float in struct",
			input:    `{"interval": 0.5}`,
			expected: 500 * time.Millisecond,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var cfg testConfig
			err := json.Unmarshal([]byte(tt.input), &cfg)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if cfg.Interval.Duration() != tt.expected {
				t.Errorf("got %v, expected %v", cfg.Interval.Duration(), tt.expected)
			}
		})
	}
}
