for batch in "01" "02" "03" "04" "05" "06" "07" "08"; do
  scripts/send_data_batch data/batch_$batch.json
sleep 5
done