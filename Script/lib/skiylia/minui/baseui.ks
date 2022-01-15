// must fit into 1kb, preferably with space remaining.

// required globals
lock con to homeconnection:isconnected.
// fetch battery percentage
for res in ship:resources { if res:name = "electriccharge" { lock bat to round(100 * res:amount / res:capacity, 1). break. }. }.
