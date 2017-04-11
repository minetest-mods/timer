
## Timer

A persistent timer class that allows restarting timers automatically
after server restarts.

The timer takes care of housekeeping and scheduling, and the mod needs
to only take care of loading+starting, and storing the timer.

The timer uses game time (seconds) for its precision, and this will
account for game pauses or game shutdown accordingly. If the game is
not running, the timers are all paused as well and accrue no further
elapsed time.

### Creating a timer

`t = Timer(func(elapsed), ...)`

Creates a new timer that will call function `func`. The elapsed time
since start of the timer, or since the last timer event is passed
as a number to the function.

The extra parameters can be either a timer state table, or two parameters
for the interval, and repeat values:

`t = Timer(func(elapsed), interval, repeats)`

Creates a new timer that executes function `func(elapsed)` every `interval`
seconds, and repeating if `repeats` equals `true`. If `repeats` is omitted,
the timer does not repeat.

A timer created with this initialer does *not* start automatically, and will
need to be started manually.


`t = Timer(func(elapsed), timertbl)`

```
timertbl = {
    interval = <number>,
    repeats = <bool>,
    active = <bool>,
    elapsed = <number>,
}
```

Creates a new timer that executes function `func(elapsed)` every `interval`
seconds, and repeating if `repeats` equals `true`. If `active` equals `true`,
the timer will be automatically started. If `elapsed` has a non-zero numerical
value, the elapsed time will be set to its value, and the timer event will
happen sooner.


### Methods

`start()`
 * starts the timer if it wasn't already started.

`stop()`
 * stops the timer if it wasn't already stopped.

`set_interval(interval)`
 * changes the interval value of the timer. If the timer is active, and
   the interval value passed is larger than the elapsed timer, the timer
   will expire immediately.

`get_interval()`
 * returns the current timer interval value.

`get_elapsed()`
 * returns the current timer elapsed value.

`is_active()`
 * returns whether the timer is currently running.

`expire(elapsed)`
 * expires the timer manually and executes the function associated with
   it. The elapsed time will be reset to 0.

`to_table()`
 * returns the state data of the timer in table format. This table
   can be passed back to the Timer initializer as described above
   under "Creating a Timer"

### Saving and restoring

The timer can be initialized from the table retrieved from `to_table()`,
and mods can re-initialize their timers in a stateful way. For example
code, please look in the `timerdemo` folder which contains a working
example that demonstrates how to use the Storage API to save and restore
a Timer.
