/**
 * Created by bsahlas on 10/24/14.
 */
package simulations.players
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

object PlayerPreviewScenario {
  val dataFile = System.getProperty("datafile")
  val duration = System.getProperty("duration").toInt
  val accountId = System.getProperty("account")
  val numPause = java.lang.Long.getLong("pause", 0L)
  val testPause = Duration(numPause, "seconds")
  val playerId = jsonFile(dataFile).circular
  var topperharley = "/v1/accounts/" + accountId + "/players/"
  val previewUrl = "/preview/embeds/default/master/index.html"

  val playerPreviewScenario = scenario("Player Preview Random Scenario")
    .during(duration seconds)  {
    feed(playerId)
      .exec {
        http("players.preview.random")
          // make the preview requests while referencing the 'id' attribute made available from the 'feed'
          .get(topperharley + "${id}" + previewUrl)
          .headers(Map("Keep-Alive" -> "115", "Cache-control" -> "no-cache" , "Content-Type" -> "application/json", "strictSSL" -> "false"))
          .check(status.is(200))
      }
      .pause(numPause)
    }
}
