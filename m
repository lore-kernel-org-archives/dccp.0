From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 10:47:32 +0000
Subject: [ANNOUNCE/RFC] Problems with Socket API: Half-Close
Message-Id: <200704021147.32221@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have been experiencing problems with the way passive-close is specified
for DCCP and developed a solution which avoids the following problem:

 When a side receives a connection termination (Close or CloseReq), it 
 can happen that the receive buffers are wiped out before the application
 had a chance to see the data; sometimes even before connect() returns.

The solution is based on implementing transitional states (PASSIVE_1/2)
for passive-close. As in TCP, these are terminated after a timeout.

I have put the concept and blurb online:

 http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/closing_states/

There are patches for this which I would like to submit along with the
remaining ones for CCID3. I'd be glad if people could have a look at this
and say if there are disagreements with the concept.

Note: This implementation concept does not affect standards-compliance 
      since the macroscopic behaviour is still compatible with RFC 4340.

I am however quite  positive that without transitional states it will not
work and the API will only function for one or two special scenarious of
socket programming.

Gerrit
