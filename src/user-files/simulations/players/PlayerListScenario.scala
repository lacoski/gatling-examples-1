package simulations.players
import java.util.{Date, Random}

import io.gatling.core.Predef._
import io.gatling.http.Predef._

import scala.concurrent.duration._


object PlayerListScenario {
  val userProfile = jsonFile("access_token.json").circular
  val duration = System.getProperty("duration").toInt
  val accountId = System.getProperty("account")
  val numPause = java.lang.Long.getLong("pause", 0L)
  val testPause = Duration(numPause, "seconds")
  var topperharley = "/v1/accounts/" + accountId + "/players/"

  val playerListScenario = scenario("Player List Scenario")
    .during(duration) {
    feed(userProfile)
      .exec {
      http("players.list.random")
        // make the preview requests while referencing the 'id' attribute made available from the 'feed'
        .get(topperharley)
        .headers(Map("Keep-Alive" -> "115", "Cache-control" -> "no-cache", "Content-Type" -> "application/json", "Authorization" -> "${accessToken}", "strictSSL" -> "false"))
        .check(status.is(200))
    }
      .pause(testPause)
  }
  }
