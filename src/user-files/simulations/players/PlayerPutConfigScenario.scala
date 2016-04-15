/**
 * Created by bsahlas on 10/24/14.
 */
package simulations.players

import java.util.{Date, Random}
import io.gatling.core.Predef._
import io.gatling.http.Predef._

import scala.concurrent.duration._


object PlayerPutConfigScenario {
  val now = new Date
  val duration = System.getProperty("duration").toInt
  val numPause = java.lang.Long.getLong("pause", 3L)
  val testPause = Duration(numPause, "seconds")

 
  /** player variables **/
  val config = """{"player":{"technology":"html","template":{"name":"single-video-template","version":"1.4.3"}}}"""
  val userProfile = jsonFile("access_token.json").random
  val dataFile = System.getProperty("datafile")
  val playerId = jsonFile(dataFile).random
 
  /** Paging variables */
  val limit = Integer.getInteger("limit", 20)
  val maxOffset = Integer.getInteger("maxOffset", 1000)
  val random = new Random
  val range = 0 to maxOffset

  def consoleLogSession(session: Session) {
    val id :String = session("player").as[String]
    session.set("playerId", session("player").as[String])
    println("player id: " + id)
    println("The Session values: " + session)
  }

  def consoleLogResponse(bodyString: Any) {
    println("Response >>>>>----------------->>>>> : " + bodyString.toString);
  }


  val playerPutConfigScenario = scenario("Put Config Scenario")
    .during(duration) {
    feed(playerId)
    .feed(userProfile)
      .exec (
      http("players.put")
        .put("/v1/accounts/${accountId}/players/${id}/configuration")
        .headers(Map("Keep-Alive" -> "115", "Cache-control" -> "no-cache", "Content-Type" -> "application/json", "Authorization" -> "${accessToken}", "strictSSL" -> "false"))
        .body(StringBody(config)).asJSON
        .check(status.is(200))
    )
      .foreach("${id}", "player") {
      exec(session => {
        session.set("playerId", session("id").as[String])
      }).exec(session => {
        consoleLogSession(session)
        session
      })
    }
  }.pause(testPause)
}