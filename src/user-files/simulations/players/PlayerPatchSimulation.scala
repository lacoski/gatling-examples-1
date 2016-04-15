package simulations.players

import simulations.players.PlayerPatchConfigScenario._
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class PlayerPatchSimulation extends Simulation {
  val baseUrl = System.getProperty("topperharley")

  val numUsers = System.getProperty("requests").toInt
  val httpConf = http
    .baseURL(baseUrl)
    .acceptHeader("application/json")
    .disableFollowRedirect
    .extraInfoExtractor( extraInfo => { List[String](extraInfo.request.getUrl) } )
    .extraInfoExtractor( extraInfo => { List[Any](extraInfo.request.getHeaders) } )
    .extraInfoExtractor( extraInfo  => { List[Any](extraInfo.response.headers) } )
  println("baseUrl " + baseUrl + "  \n ***\n")
  setUp(
    playerPatchConfigScenario.inject(
      atOnceUsers(numUsers)
    ).protocols(httpConf)

  )
}
