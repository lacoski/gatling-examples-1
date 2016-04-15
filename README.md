Performance Testing PlayerManagementAPI with Gatling
=======

This project using Gatling.  Gatling is an open-source load testing framework based on Scala, Akka and Netty

@See http://gatling.io

####Included in this project
* gatling libraries (gatling v2.0.1 & compatible with v2.0.X)
* do-gatling-player.sh - this is a shell script used to execute the preview test simulation scenarios

####Gatling Report Documentation
* http://gatling.io/docs/2.1.7/general/reports.html

####Setup
* You need to clone this repo. It includes all of the test files and the files needed by the gatling runtime 
* make sure that JAVA_HOME is set to your java runtime
    * ex: export JAVA_HOME='/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home'
    
    
Performance testing using this utility is allowed for dev and qa environments only!

In the $GATLING_HOME/bin folder typing the following './do-gatling-player.sh -?' will print out the help messagd for the script
~~~
Usage:
  do-gatling-player.sh (-a account -e env -v verb
  -t duration -r requests -d datafile  -? help) (commands)


./do-gatling-player.sh -a 1137972973 -e qa -v preview -t 60 -r 100
 -d ../player-ids.json -s random
~~~  

* -v verb - preview and list are supported
* -d datafile - a file containing player id(s) to be fed to gatling test scenario. 
    * Example file contents containing 2 ids [{"id":"1234"},{"id":"4321"}]
* -t duration - time in seconds to run the test
* -r requests - number of simultaneous request connections

 

###### Example 1
~~~
./do-gatling-player.sh -d ../player-ids.json -t 60 -r 10 -e qa -a $ACCOUNT_ID_PERF
~~~

In this example scenario we want to test 10 simultaneous preview request connections for a single preview and
repeat it 5 times.
~~~
* ../player-ids.json - contains a player in this format: [{"id":"1234"},{"id":"4321"},...]
* 60 = duration in seconds 
* 10 = simultaneous requests (users)
~~~

###### Example 2
~~~
./do-gatling-player.sh -d ../player_ids_pbuilder_many.json -t 60 -r 50 -e development -a $ACCOUNT_ID_PERF
~~~

In this example scenario we specify
~~~
* ../player_ids_pbuilder_many.json - contains an array of 100 json object 
ex: [{"id":"02a8f873-9939-419f-b6a5-e3d6a2f2e83f"}, ...]
* 5 = duration (count)
* 50 = simultaneous requests (users)

~~~

##### Quick Start for "List" testing
While testing locally (and on QA) you should use the performance accounts
~~~
export ACCOUNT_ID_PERF=1137972973
export ACCOUNT_ID_PERF_ALT=1321442667
~~~
* clone the videocloud/player-gatling-performance repo
* git clone git@bithub.brightcove.com:videocloud/player-gatling-performance.git

Use doit to setup your data and the primary performance account.  Make sure that the players list is 0 for the account your going to use
you can create the players and embeds using combination commands like these
~~~
./doit.js deleteAll -a $ACCOUNT_ID_PERF
./doit.js list // this sets up a default embed
./doit.js create createEmbeds%250
./doit.js create createEmbeds%250
./doit.js create createEmbeds%250
./doit.js create createEmbeds%250
./doit.js create createEmbeds%250
~~~
After doing that for 10 players finish creating the 1000 by running this 
~~~
./doit.js createPlayers%990
~~~
cd to /Users/bsahlas/dev/mainline/player-gatling-performance/src/bin
run
~~~
./do-gatling-players.sh -i 1 -r 10 -a $ACCOUNT_ID_PERF
~~~

##### How to run the tests
Gatling tests are executed using the java runtime.  Not only does this repo contain the test cases (simulations and scenarios scala classes) but it also contains the java libs and configurations files needed by gatling.  The libs are the same version of gatling which the classes we developed on - Gatling version 2.0.1.  Gatling itself seems to have a tight release cycle. 

*note* : the first time you run a test **all** of the scala classes in the class path are compiled.  If class code is modified or classes are added to the project/package they'll be compiled the next time the test is run.


First, you have to create the players that you want to preview.  I also make sure that my test environment is clean, so I run this doit command to remove any players for the account that I'm testing against.

~~~
./doit.js deleteAll -e $ENV -a $ACCOUNT_ID_PERF
~~~
Now create the number of players that you want to test. All the players can be created using this method.  

Be sure that NGINX is not enabled or you'll be throttled and unable to create as many in one shot.
scripts(master): env |grep NGINX
PLAYERMANAGEMENT_NGINX=false
USE_NGINX=false

Run these doit cmds

~~~
export env=development 
export ACCOUNT_ID_PERF=1137972973

di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
di create createEmbeds%250 -e $env -a $ACCOUNT_ID_PERF
~~~
After doing that for 10 players, finish creating the 1000 by running this
~~~
di createPlayers%990 -e $env -a $ACCOUNT_ID_PERF  
~~~
You may have to break this up into smaller chunks depending on your performance.  Tokens last only 5 minutes and creating 990 players might exceed that timeframe so to avoid 404s perhaps di createPlayers%300 would be better and run that a few times to reach your quota.

There exists a method in doit.js which will create a list of player ids to a file for you
~~~
./doit.js listPlayersToFile -e $env -a $ACCOUNT_ID_PERF
~~~

**Saving the player_management data**

I used these commands to make a backup of the data from the preceding steps
stop mongo if it is running and execute this mongodump cmd
~~~
mongodump -v --dbpath=/Users/bsahlas/dev/mainline/mongodata/data/db -d player_management --journal --out ~/dump/thdb/
~~~

In order to restore the database to your current player_management db run the following
~~~
mongorestore --dbpath /Users/bsahlas/dev/mainline/mongodata/data/db ~/dump/thdb/
~~~


On QA too
If you were able to have created all those players on QA then grab the ids and make the datafile
~~~
./doit.js listPlayersToFile -e q -a ACCOUNT_ID_PERF
~~~
Once you run this a file named player-ids.json is created and you wind up with is &lt;topperharley&gt;/scripts/response/player-ids.json 
~~~
[{"id":"01e47f04-87bd-4ca8-a819-704c204412db"},
{"id":"02a548cd-8275-4488-9630-ffd56b1dcba3"},
{"id":"04b3fe8e-9162-4dfb-bbc1-c72e4d8ee99d"},
{"id":"04bbd537-a91a-47b9-9c2e-c72609f8d7d8"},
{"id":"06fa8e56-8f02-4a07-b481-698c90a4d018"},
{"id":"0727ef7e-0d5a-4c5d-8964-6d2db1422632"},
{"id":"096dd0e3-e47a-442f-ad49-06f8bd6d6f6f"},
{"id":"0a1214ed-611c-4a0d-aab4-29069f0975e8"},
{"id":"0ace4257-4812-4c44-b206-4574261d08c8"},
...
{"id":"ed52fa40-c6d9-46bd-9637-6b53ffd743cf"},
{"id":"ede8e900-2547-4e44-bce7-bd75ec13ee97"},
{"id":"ee332d16-6f9c-493d-a1a3-2c030d92f2a2"},
{"id":"f8d28eec-7588-4cc5-8291-9afab4ea3a8e"},
{"id":"fb9fd156-32a6-4087-8d34-423ea444e52f"},
{"id":"fbfc7bb6-3241-40c6-be14-82b2ba8db42d"}]
~~~

Copy the player-ids.json file over to the root dir of this project.  

~~~
cp ./responses/player-ids.json $GATLING_HOME/player-ids.json
~~~

Do it all in one shot!
~~~
./doit.js listPlayersToFile -e $env -a $ACCOUNT_ID_PERF; cp ./responses/player-ids.json $GATLING_HOME/player-ids.json
~~~

Let's assume that you created 1000 embeds. Now you have a player-ids.json file containing 1000 ids, 10 of which have 250 embeds each (plus 1 default). So, based on the reference example from above, when you run this statement
~~~
./do-gatling-player.sh -a $ACCOUNT_ID_PERF -e development -v preview -d ../player-ids.json -i 1 -r 10 -s random 
~~~
What gatling executes is this:
First it establish security tokens and determines what environment you're in. Then it executes 10 simultaneous requests for 10 distinct player preview urls, for 1 iteration. The player ids are selected randomly from the data file.  Even though the player-ids.json contains 100 ids the code knows feed only 10 ids from the data feeder file.

Here is the output from the run: [See the output](https://s3.amazonaws.com/uploads.hipchat.com/18835/815492/K4Kbh5Cgc8WQcAZ/upload.png)

Note that it prints out the location of the report that you can open in a browser (similar to other webby tools like istanbul/code coverage UI)

~~~
Reports generated in 0s.
Please open the following file: /Users/bsahlas/dev/mainline/player-gatling-performance/src/user-files/results/playerpreviewrandomsimulation-1445360965774/index.html
~~~

You can also find the Gatling HTML report under the src/userfiles/results folder

~~~~
- results
    - playerpreviewrandomsimulation-1418216944809
        - index.html
~~~~        

Note: Each time you run the script the cleanup method is called to clear out the reports from the previous run.


#####About how this app generates access tokens

_Currently in order to perform any of our api actions other than preview a player it is required to create auth tokens. These
are not-long-lived, however for our current requirements we do not need more time than the 5 minute token timeout gives us.
Generating tokens is handled in the do-gatling-*.sh scripts for the specified accountId, client_id and client_secret. Once basic 
authentication is available for all our apis we can switch to that and remove auth token requests and get the benefit of long-lived
tokens._


The access_token is required to GET, POST, PUT, PATCH and DELETE - basically, any api request other than
a preview url request requires authentication from Cathy.  

We are able to generate the access tokens as part of the script execution.  See the do-gatling*.sh scripts for the 
complete definition but here is the line that generates the actual access_token.json file from the parse_access_token function

```
echo '[{"accountId": "507017973001", "accessToken": "Bearer '`echo ${temp##*|}`'" }]' >| "access_token.json"
```
What you get in the access_token.json file which is fed into the gatling code as an array of json objects.  Multiple accounts can be used if required.
```
[
  {
    "accountId": "507017973001",
    "accessToken": "Bearer APUCif_QOwrrK_-c_..."
  }
]
```

The token is fed into a given scenario - for example, take a look at the simulations.players.PlayerListScenario scala class.

First you set the user profile var based on the info in the access_token.json. The JSON data includes a valid auth token.

```val userProfile = jsonFile("access_token.json")```

Then, later on in the scala code, the auth token is passed with the request as a header

```.headers(Map("Keep-Alive" -> "115", "Cache-control" -> "no-cache", "Content-Type" -> "application/json", ``` "Authorization" -> "${accessToken}", ```"strictSSL" -> "false"))```
