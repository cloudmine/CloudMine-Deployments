############################### Credentials needed in ENVARS #######################################

    #username=${USERNAME:-"your username"}
    #password=${PASSWORD:-"your password"}
    #siteid=${SITE_ID:-"the site ID from the dash"}
    #file_path=${FILE_PATH:-"the absolute file path for the zip package to be uploaded"}
    #root_url=${ROOT_API_URL:-"https://$ROOT_API_URL"}
    #root_dashboard_url=${ROOT_DASHBOARD_URL:-"https://chc.cloudmine.io"}

############################### Auth and Store Valid JWT. Validation kills script if creds are incorrect. #######################################

echo "logging you in..."

token=$(curl -X POST \
  https://$ROOT_API_URL/v2/auth/developer/login \
  -H "Cache-Control: no-cache" \
  -H "Content-Type: application/json" \
  -d "{ \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" }" \
  | jq '.data.token' | tr -d '"')

  if [ -z $token ]; then
    echo "Invalid credentials, please update your credentials and try again."
    exit
  fi

  echo "Successfully logged in!"


############################### Upload Hosted Site to Specified Hosted Site ID #######################################

echo "uploading your site!"

curl -X POST \
  https://$ROOT_DASHBOARD_URL/api/site/$SITE_ID/upload \
  -H "Authorization: Bearer $token" \
  -H "Cache-Control: no-cache" \
  -H "Content-Type: multipart/form-data" \
  -F file=$FILE_PATH


############################### Website Health Check #######################################

echo "upload complete, checking health of site..."

sitename=$(curl -X GET \
  https://$ROOT_API_URL/v2/hosted_site/$SITE_ID \
  -H "Authorization: Bearer $token" \
  -H "Cache-Control: no-cache" \
  | jq '.hostnames[0]' |tr -d '"')


 if [ "$sitename" = null ]; then
    echo "hostname returned a value of null"
    echo "The hostname is invalid or not available. Please check the hostnames for your site and try again."
    exit
  fi

  echo "**** found hostname: $sitename ****"

force_ssl_bool=$(curl -X GET \
  https://$ROOT_API_URL/v2/hosted_site/$SITE_ID \
  -H "Authorization: Bearer $token" \
  -H "Cache-Control: no-cache" \
  | jq '.force_ssl' |tr -d '"')


if [ "$force_ssl_bool" = true ]; then
  ssl="https://"
fi

if [ "$force_ssl_bool" = false ]; then
  ssl="http://"
fi

http_status_code=$(curl -s -o /dev/null -w "%{http_code}" $ssl$sitename)

echo "$http_status_code"


if [ "$http_status_code" -eq 200 ]; then
  echo "Your deployment was successful and your site is live";
fi

if [ "$http_status_code" -eq 403 ]; then
  echo "Your deployment failed. Please check your values and try again.";
fi

if [ "$http_status_code" -eq 404 ]; then
  echo "Your deployment failed. Please check your values and try again.";
fi