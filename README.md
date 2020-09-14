# procmail-thread

The two scripts here can be used from procmail to perform actions
depending on their membership within a thread.

I haven't spent basically any time on these for cleanliness; that is,
they definitely need work, and probably fail in all sorts of ways in
more obscure contexts.

You can use this in procmail like so:

```
:0 Wfh: formail.lock
| $HOME/src/procmail-thread/match-thread.sh $HOME/.refs.muted "Procmail-Muted: true"

:0 Wfh: formail.lock
| $HOME/src/procmail-thread/match-thread.sh $HOME/.refs.watched "Procmail-Watched: true"

:0
* X-Mailing-List:.*linux-kernel@vger.kernel.org
{ DEST=linux }

:0
* Procmail-Muted: true
{
        SWITCHRC=$HOME/.procmailrc.markread
}

:0
* Procmail-Watched: true
{
        :0 c:
        $DEFAULT

        SWITCHRC=$HOME/.procmailrc.markread
}

:0
$DEST/
```

Where `.procmailrc.markread` is this lovely piece of copy-and-paste
magic:

```
#
# Courtesy of https://stuffphilwrites.com/2011/01/ultimate-procmail-recipe/
#

:0
{
  :0c # store as new
  "$DEST/"

  :0 # move to cur/ and append a :2,S to mark as read ("seen")
  * LASTFOLDER ?? /\/[^/]+$
  { tail=$MATCH }
  TRAP="mv '$LASTFOLDER' '$DEST/cur/$tail:2,S'"

  HOST
}
```

Essentially, if we find the thread in `.refs.muted`, then we will
deliver the mail as already-read (this presumes we're using Maildir). If
we're watching the thread, then we'll carbon-copy it to the default dir
as well.

Of course, you could just redirect muted threads to a different folder,
`/dev/null`, etc.

To mark a particular thread, use `add-thread.sh`. For example, in mutt,
I have:

```
macro index,pager "M" "|~/src/procmail-thread/add-thread.sh ~/.refs.muted<return>"
macro index,pager "W" "|~/src/procmail-thread/add-thread.sh ~/.refs.watched<return>"
```
