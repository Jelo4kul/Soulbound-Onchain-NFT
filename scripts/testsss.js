var foodCoords, KEY = {
            w: 87,
            a: 65,
            s: 83,
            d: 68,
            space: 32
        }, moveSpeed = 20, score = 0, highScores = [], snakeHead = document.getElementById("snake"), svg = document.getElementsByTagName("svg")[0], startText = document.getElementById("startText"), directions = document.getElementById("directions"), food = document.getElementById("food"), scoreCounter = document.getElementById("scoreCounter"); startText.textContent = "press space to start", directions.textContent = "then w, a, s, d";
        var snakeBody = []; isTurning = !1, isRunning = !1;
        var currentDirection = "right"; 
        document.documentElement.addEventListener("keydown", e => {
            handleInput(e)
        }, !1);
        var timerFunction = null;

        function startGame() {
            null == timerFunction && (timerFunction = setInterval(go, 80), random_food(), startText.textContent = "", directions.textContent = "", scoreCounter.textContent = score, isRunning = !0)
        }

        function updateScore() {
            score += 1, scoreCounter.textContent = score
        }

        function random_food() {
            var e = Math.floor(30 * Math.random()),
                t = Math.floor(30 * Math.random());
            e + 200 > 780 && (e = 780), t + 200 > 780 && (t = 780), foodCoords = [20 * e + 200, 20 * t + 200], food.setAttribute("x", 20 * e + 200), food.setAttribute("y", 20 * t + 200)
        }

        function updateHighScore() {
            var e = highScores.length;
            if (score <= highScores[e - 1] || highScores.includes(score)) return;
            e >= 5 && highScores.pop();
            let t = highScores.findIndex(e => score > e);
            highScores.splice(t, 0, score);
            for (var n = 1; n <= highScores.length; n++) {
                document.getElementById(`hs${n}`).textContent = highScores[n - 1]
            }
        }

        function reset() {
            if (1 != isRunning) {
                document.documentElement.removeEventListener("keydown", function(e) {
                    handleInput(e)
                }, !1), clearInterval(timerFunction), timerFunction = null, isTurning = !1;
                for (var e = 0; e < snakeBody.length; e++) svg.removeChild(snakeBody[e]);
                snakeBody = [], scoreCounter.textContent = score = 0, food.setAttribute("x", -50), food.setAttribute("y", -50), startText.textContent = "press space to start", directions.textContent = "then w, a, s, d", snakeHead.setAttribute("x", 500), snakeHead.setAttribute("y", 500), document.documentElement.addEventListener("keydown", function(e) {
                    handleInput(e)
                }, !1)
            }
        }

        function appendSnake() {
            var e = snakeHead.cloneNode(!0),
                t = snakeBody.length;
            t > 0 && (e.setAttribute("x", 1 * snakeBody[t - 1].getAttribute("x")), e.setAttribute("y", 1 * snakeBody[t - 1].getAttribute("y"))), snakeBody.push(e), svg.appendChild(e)
        }

        function updateSnake() {
            for (var e = 1 * snakeHead.getAttribute("x"), t = 1 * snakeHead.getAttribute("y"), n = snakeBody.length - 1; n >= 0; n--)
                if (0 == n) snakeBody[0].setAttribute("x", e), snakeBody[0].setAttribute("y", t);
                else {
                    var o = 1 * snakeBody[n - 1].getAttribute("x"),
                        r = 1 * snakeBody[n - 1].getAttribute("y");
                    if (snakeBody[n].setAttribute("x", o), snakeBody[n].setAttribute("y", r), o == e && r == t) {
                        isRunning = !1, updateHighScore(), reset();
                        break
                    }
                } isTurning = !1
        }

        function go() {
            var e = 1 * snakeHead.getAttribute("x"),
                t = 1 * snakeHead.getAttribute("y");
            if (updateSnake(), 1 == isRunning) switch (currentDirection) {
                case "right":
                    snakeHead.setAttribute("x", e += moveSpeed);
                    break;
                case "left":
                    snakeHead.setAttribute("x", e -= moveSpeed);
                    break;
                case "up":
                    snakeHead.setAttribute("y", t -= moveSpeed);
                    break;
                case "down":
                    snakeHead.setAttribute("y", t += moveSpeed)
            }(e <= 180 || e >= 800 || t <= 180 || t >= 800) && (isRunning = !1, updateHighScore(), reset()), e == foodCoords[0] && t == foodCoords[1] && (random_food(), updateScore(), appendSnake())
        }

        function handleInput(e) {
            if (e.keyCode == KEY.space && startGame(), 1 != isTurning) switch (isTurning = !0, e.keyCode) {
                case KEY.w:
                    "down" != currentDirection && (currentDirection = "up");
                    break;
                case KEY.s:
                    "up" != currentDirection && (currentDirection = "down");
                    break;
                case KEY.a:
                    "right" != currentDirection && (currentDirection = "left");
                    break;
                case KEY.d:
                    "left" != currentDirection && (currentDirection = "right")
            }
        }