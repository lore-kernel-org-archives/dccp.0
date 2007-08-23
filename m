From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Aug 2007 15:25:16 +0000
Subject: [RFC]: Feature negotiation
Message-Id: <200708231625.16320@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

For some time I have been working away at improving feature negotiation support,
following a discussion with Ian regarding the disabling of Ack Vectors.

I have found some limitations of the present implementation and would like to fix
this. There is full documentation on the issues on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/

It is not necessary to read all of this, what I would like people to have a look at
and would value comments for are the implementation notes on:

http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html#concept

Please do send comments, suggestions etc.

There are some good ideas in the present implementation; some of the problems encountered are:

 * if one end is configured to use CCID2, the other CCID3, then both end up
   using these values (with horrible performance results);

 * when changing features anytime during a conversation, traffic needs
   to be stopped until negotiation is over (no provision currently made);

 * negotiation during connection setup changes the properties of the
   listening socket rather than the child socket (accept queue); i.e.
   if the first incoming connection requests CCID3, the listening socket
   changes from CCID2 to CCID3; the second incoming connection may again
   change this, and so on;

 * the code uses some ingenuous, but cryptic wizardry. It is hard to figure
   out how parameters are negotiated, which makes the code prone to oversights
   (in dccp_feat_update_ccid() for instance, RX and TX CCID are reversed, it
   should be the other way around);

 * receiving empty confirms is currently not handled.

