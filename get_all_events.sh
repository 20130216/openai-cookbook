#!/bin/bash

API_URL="https://api.openai.com/v1/fine_tuning/jobs/ftjob-nkWYgJHlEqo1soJAZ6xzKuKq/events"
AUTH_HEADER="Authorization: Bearer $OPENAI_API_KEY"
PER_PAGE=100  # 每页获取的事件数量
OUTPUT_FILE="events.json"

# 初始化空的JSON数组
echo "[]" > $OUTPUT_FILE

page=1
while true; do
  echo "Fetching page $page..."
  response=$(curl -s "$API_URL?page=$page&per_page=$PER_PAGE" -H "$AUTH_HEADER")
  
  # 检查响应是否为空
  if [ "$(echo $response | jq '.data | length')" -eq 0 ]; then
    echo "No more data. Stopping."
    break
  fi
  
  # 将当前页的事件记录追加到文件中
  jq -s '.[0] + .[1]' $OUTPUT_FILE <(echo $response | jq '.data') > temp.json
  mv temp.json $OUTPUT_FILE
  
  ((page++))
done

echo "All events have been written to $OUTPUT_FILE"