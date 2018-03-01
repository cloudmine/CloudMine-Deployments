############################### Step One Deploy #######################################
 
curl -X POST \
  https://api.cloudmine.io/admin/app/${app_id}/code/upload/${language} \
  -H 'Cache-Control: no-cache' \
  -H "X-CloudMine-ApiKey: ${master_api_key}" \
  -H 'content-type: multipart/form-data;' \
  -F file=@deploy-code.zip
 
############################### Get JWT for Status Check ##############################
 
token=$(curl -X POST \
  https://api.cloudmine.io/v2/auth/developer/login \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d "{ \"username\": \"${username}\", \"password\": \"${password}\" }" \
  | jq '.data.token' | tr -d '"')
 
############################### Status Check Then Exit #################################
 
seconds=$((5 * 60))
while [ $seconds -gt 0 ]; do
  status=$(curl -X GET \
    https://compass.cloudmine.io/dashboard/v1/app/${app_id}/apollo/status \
    -H "Authorization: Bearer $token" \
    -H 'Cache-Control: no-cache' | jq '.health.HealthStatus')
  if [ "$seconds" == 1 ]; then exit 2
  elif [ "$status" == \"Ok\" ]; then exit
  else echo "$status" ; sleep 1 ; : $((seconds--)) ; fi
done