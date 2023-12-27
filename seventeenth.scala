import scala.io.Source
import scala.collection.mutable.PriorityQueue
import scala.annotation.tailrec
import scala.collection.mutable.HashSet
import scala.collection.immutable.LazyList.cons
import scala.collection.mutable.HashMap

enum Direction(val id: Int):
  case Right extends Direction(0)
  case Up extends Direction(1)
  case Left extends Direction(2)
  case Down extends Direction(3)

object Direction {
  implicit val ordering: Ordering[Direction] = new Ordering[Direction] {
    override def compare(x: Direction, y: Direction): Int = x.id - y.id
  }
}

type Coordinate = (Int, Int)

def readFile: (Int, String) =
  val content = Source.fromFile("seventeenth.txt").mkString
  val rowLength = content.indexWhere(_ == '\n')
  (rowLength, content.filter(_ != '\n').mkString)

@main def main: Unit =
  val (rowLength, content) = readFile

  def heatLossOf(coordinate: Coordinate): Int =
    content.charAt(coordinate._1 + coordinate._2 * rowLength).asDigit

  @tailrec
  def heatLoss(
      pQueue: PriorityQueue[(Int, Int, Direction, Coordinate)],
      visited: HashSet[(Coordinate, Direction, Int)]
  )(
      filterBy: (Direction, Direction, Int) => Boolean
  ): Int =
    var t = pQueue.dequeue()
    while (visited.contains((t._4, t._3, t._2)))
      t = pQueue.dequeue()
    val (currentHeatLoss, consecutive, direction, (x, y)) = t
    // println(f"($currentHeatLoss, $direction, ($x, $y), $consecutive)")
    if ((x, y) == (rowLength - 1, rowLength - 1)) currentHeatLoss
    else {
      val nextSteps = LazyList(
        (Direction.Right, (x + 1, y)),
        (Direction.Up, (x, y - 1)),
        (Direction.Left, (x - 1, y)),
        (Direction.Down, (x, y + 1))
      )
        .filter((d, _) => (d.id - direction.id).abs % 4 != 2)
        .filter { case (_, (x, _)) => 0 <= x && x < rowLength }
        .filter { case (_, (_, y)) => 0 <= y && y < rowLength }
        .filter((nextDirection, _) =>
          filterBy(nextDirection, direction, consecutive)
        )
        .map((d, pos) =>
          val nextHeatLoss = currentHeatLoss + heatLossOf(pos)
          val nextConsecutive = if (d == direction) consecutive + 1 else 1
          (nextHeatLoss, nextConsecutive, d, pos)
        )
      pQueue.addAll(nextSteps)
      visited.add(((x, y), direction, consecutive))
      heatLoss(pQueue, visited)(filterBy)
    }

  val ord = Ordering[(Int, Int, Direction, Coordinate)].reverse

  val pQueue1 = PriorityQueue((0, 0, Direction.Right, (0, 0)))(ord)
  val part1 = heatLoss(pQueue1, HashSet()) {
    (nextDirection, direction, consecutive) =>
      consecutive < 3 || nextDirection != direction
  }
  println("Part 1: " + part1)

  val pQueue2 = PriorityQueue(
    (0, 0, Direction.Right, (0, 0)),
    (0, 0, Direction.Down, (0, 0))
  )(ord)
  val part2 = heatLoss(pQueue2, HashSet()) {
    (nextDirection, direction, consecutive) =>
      (consecutive < 4 && nextDirection == direction) || consecutive >= 4 && consecutive < 10 || (consecutive >= 10 && nextDirection != direction)
  }
  println("Part 2: " + part2)
