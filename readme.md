
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

`t = Timer(func(elapsed), timerdata)`

Creates a new timer that will call function `func`. The elapsed time
since start of the timer, or since the last timer event is passed
as a number to the function.

`timerdata` Is a table that contains either default values for the
timer, or a storage ref and storage key name to use for storing and
retrieving the timer data in case the timer was saved before.

```
timerdata = {
    storage = <mod storage ref>,
      -- Optional. handle to mod storage API. See
      -- `minetest.get_mod_storage()` documentation in minetest
      -- engine API documentation.
    key = <string>,
      -- Optional. string name of key used. This will be the name
      -- of the key used to store and load timer data, and should
      -- not be used in other fashion.
    interval = <number>,
      -- Required. Specifies the default interval value for
      -- new timers. Not used when the timer was previously saved.
    repeats = <bool>,
      -- Optional. Specifies whether the timer should repeat, or
      -- stop after expiring once. If omitted, defaults to `true`.
    active = <bool>,
      -- Do not specify. Used for internal state keeping.
    elapsed = <number>,
      -- Do not specify. Used for internal state keeping.
}
```

If `storage` and `key` members are available, the timer code will attempt
to retrieve the timer data from the storage location and key passed,
and other parameters are ignored. If the timer was started, it will
be automatically started again.

If the storage did not contain saved timer data, the timer is created
from the default parameters passed, but **not started**.

If no `storage` ref or `key` was passed, the timer will not be started,
but will be created with the default interval and (optional) repeats
value.

### Demo

A full timer demo that demonstrates the code's use is included as a
runnable mod under the folder `timerdemo` in the source code tree. To
use it, copy the whole folder into your mod folder and enable it in
your worlds config.


### Methods

`start()`
 * starts the timer if it wasn't already started.

`stop()`
 * stops the timer if it wasn't already stopped.

`set_interval(interval)`
 * Changes the interval value of the timer. If the timer is active, and
   the interval value passed is larger than the elapsed timer, the timer
   will expire immediately.

`get_interval()`
 * Returns the current timer interval value.

`set_repeats(repeats)`
 * Changes the timer to repeat if `repeats == true`, or stop repeating.
   otherwise.

`get_repeats()`
 * Returns whether the timer is repeating.

`get_elapsed()`
 * Returns the current timer elapsed value.

`is_active()`
 * Returns whether the timer is currently running.

`expire(elapsed)`
 * Expires the timer manually and executes the function associated with
   it. The elapsed time will be reset to 0.

`to_table()`
 * Returns the state data of the timer in table format. This table
   can be passed back to the Timer initializer as described above
   under "Creating a Timer"

`save()`
 * Stores the timer data into the previously passed `storage` ref at the
   `key` key. If `storage` or `key` were not passed at initialization time
   causes an `assert()`.

