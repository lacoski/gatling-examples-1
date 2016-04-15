/**
 * Created by bsahlas on 10/24/14.
 */
package simulations.players

import java.util.{Date, Random}
import io.gatling.core.Predef._
import io.gatling.http.Predef._

import scala.concurrent.duration._


object PlayerPatchConfigScenario {
  val now = new Date
  val duration = System.getProperty("duration").toInt
  val numPause = java.lang.Long.getLong("pause", 3L)
  val testPause = Duration(numPause, "seconds")
  val dataFile = System.getProperty("datafile")

  /** player variables **/
  val config = """{"description":"patched by gatling"}"""
  val userProfile = jsonFile("access_token.json").random
  val playerId = jsonFile(dataFile).random
  /** Paging variables */
  val limit = Integer.getInteger("limit", 20)
  val maxOffset = Integer.getInteger("maxOffset", 1000)
  val random = new Random
  val range = 0 to maxOffset

  def consoleLogSession(session: Session) {
    println("The Session values: " + session)
    val id :String = session("player").as[String]
    session.set("playerId", session("player").as[String])
    println("+++++ player id: " + id)
  }

  def consoleLogResponse(bodyString: Any) {
    println("Response >>>>>----------------->>>>> : " + bodyString.toString);
  }


  val playerPatchConfigScenario = scenario("Patch Config Scenario")
    .during(duration) {

    feed(playerId)
    .feed(userProfile)
      .exec(
        http("players.patch")
          .patch("/v1/accounts/${accountId}/players/${id}")
          .headers(Map("Keep-Alive" -> "115", "Cache-control" -> "no-cache", "Content-Type" -> "application/json", "Authorization" -> "${accessToken}", "strictSSL" -> "false"))
          .body(StringBody(config)).asJSON
          .check(status.is(202))
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