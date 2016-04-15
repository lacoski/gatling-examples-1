# ---- SHELL SCRIPT ----
#!/bin/bash
export GATLING_HOME="`( cd \"../\" && pwd )`"
export GATLING_WORKSPACE=$GATLING_HOME

#set the user-files locaton
export test_dir=$GATLING_WORKSPACE/user-files


#default account
cd $GATLING_HOME
export LANG=en_US.UTF-8

# default vars
datafile=$GATLING_HOME/player-ids.json
requests=1
duration=1

user=dontpanic@brightcove.com
password=joejoe
account_id=$ACCOUNT_ID_PERF

account_all=all
env=local
template=
action=

function setEnv {
 if [[ $env == q* ]]; then
    oauth_url=https://oauth.qa.brightcove.com/v2/
    oauth_internal_url=https://10.100.193.71/cathy/private/v3
    signin_url=https://signin.qa.brightcove.com/login
    topperharley_preview_url="http://preview-players.qa.brightcove.net"
    topperharley_url="http://players.api.qa.brightcove.com"
    dangerzone_url="https://repos.api.qa.brightcove.com"
    echo ++++ QA Environment ++++

  else
    oauth_url=https://oauth.qa.brightcove.com/v2/
    oauth_internal_url=https://10.100.193.71/cathy/private/v3
    signin_url=https://signin.qa.brightcove.com/login
    topperharley_url="http://127.0.0.1:3001"
    topperharley_preview_url=$topperharley_url
    dangerzone_url="http://127.0.0.1:3003"
    echo ++++ LOCAL Environment ++++

  fi
  echo Environment Settings
  echo topper harley URL: $topperharley_url
  echo oauth URL:   $oauth_url
  echo signin URL:  $signin_url
  echo
}

function do_action {
  case $action in
    "preview")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerPreviewSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    "list")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerListSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    "create")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerCreateSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    "publish")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerPublishSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    "put")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerPutSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    "patch")
      echo "Do the following" $action
      JAVA_OPTS=$JAVA_OPTS bin/gatling.sh -s simulations.players.PlayerPatchSimulation -df $test_dir/data -sf $test_dir/simulations -rf $test_dir/results
      ;;
    *) echo "no additional instructions have been provided for that action " $action
      ;;
  esac
}

function get_account_info {
  # set correct client_id:client_secret for the account. These are good for dev/qa
  echo "set client info for $account_id"
  case $account_id in
    $ACCOUNT_ID_PERF)
    client_id=712766e9-4120-4518-8bc8-e206d92ed014
    client_secret=4o0VfhDpEVjQiM3JjSL7J8FqOMGaO9elvqNbS5x1APnT6WxHyQ7rSjyfywQVsiYe3Y3ckY3VEmR1v7OTiddkxg
      ;;
    $ACCOUNT_ID_PERF_ALT)
      export client_secret=HlnxlDvPay_rjeDWLpuIDujOLuHPVMOTZlGdgY5j2KZrhWiUS73gnmGoxE1wgGUzwq0gXOaNUZ4px2WZ7LwlCQ
      export client_id=cfbcaed9-18ca-43d7-93e5-2fdc5f7acea7
      ;;
    $ACCOUNT_ID)
      export client_secret=LZIBRhYY4z-y687pI1Efn9wwe1OQmlF7d1q1-Aw5hoRhynlfS34cELfTMBTf9wITH-Jv9iSNII1oipHZ3fs-3Q
      export client_id=be70c39b-2c0e-40c5-b568-3fb9d8beacfb
      ;;
    *) echo "no additional account information is setup for this account: " :$account_id
      exit 1
      ;;
   esac
}

function get_token {
	access_token_json=`curl --silent -i -k --user $client_id:$client_secret -d 'grant_type=client_credentials' "https://oauth.qa.brightcove.com/v4/access_token"`
}

function parse_access_token {
	prop='access_token'
    temp=`echo $access_token_json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
    #parse json object and extract the access_token to $oauth_token
    oauth_token=`echo ${temp##*|}`
    echo '[{"accountId": ' $account_id ', "accessToken": "Bearer '`echo ${temp##*|}`'" }]' >| "access_token.json"
}

#this when enabled will run each time in between test runs, disabled by default or copy the results to another location
function clean_results_folder {
    echo "Cleaning the results folder..."
    rm -rf ~/IdeaProjects/player-management-performance/gatling/src/user-files/results/*
}

function run {
  echo
  echo
  echo "Starting run on $env with $requests requests and datafile $datafile."
  echo
  echo

  if [[ $action == preview ]]; then
    JAVA_OPTS="-Daccount=$account_id -Duser=$user -Dpassword=$password -Ddatafile=$datafile -Dduration=$duration"
    JAVA_OPTS=$JAVA_OPTS" -Drequests=$requests -Dtopperharley=$topperharley_preview_url"
  fi
  if [[ $action == put ]] || [[ $action == patch ]] || [[ $action == publish ]] || [[ $action == create ]] || [[ $action == list ]]; then
    JAVA_OPTS="-Daccount=$account_id -Duser=$user -Dpassword=$password -Ddatafile=$datafile -Dduration=$duration"
    JAVA_OPTS=$JAVA_OPTS" -Drequests=$requests -Dtopperharley=$topperharley_url"
  fi

  do_action
}


# parse commandline inputs
while getopts "a:e:t:d:r:v:?" OPTION
do
  case $OPTION in
    a)
      account_id=$OPTARG
      echo Using account id: $account_id
      ;;
    e)
      env=$OPTARG
      echo Running on $env
      ;;
    r)
      requests=$OPTARG
      echo number of simultaneous requests is $requests
      ;;
    t)
      duration=$OPTARG
      ;;
    d)
      datafile=$OPTARG
      ;;
    v)
      action=$OPTARG
      ;;
    ?)
      echo
      echo "Usage:"
      echo "  do-gatling-player.sh (-a account -e env -v verb"
      echo "  -t duration -r requests -d datafile  -? help) (commands)"
      echo
      echo
      echo "./do-gatling-player.sh -a $ACCOUNT_ID_PERF -e qa -v preview -t 60 -r 10"
      echo " -d ../player-ids.json"
      echo
      echo
      echo
      exit
      ;;
    esac
done
  setEnv
  get_account_info
  get_token
  parse_access_token
  clean_results_folder

run
