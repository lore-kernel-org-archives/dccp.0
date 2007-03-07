From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 07 Mar 2007 07:19:39 +0000
Subject: Re: [PATCH 1/2][DCCP]: Correctly split CCID half connections
Message-Id: <200703070719.40067@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70703060811l21b9e3edm2da0346f920ff3cd@mail.gmail.com>
In-Reply-To: <39e6f6c70703060811l21b9e3edm2da0346f920ff3cd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am sorry for causing you inconvenience, but I have realised that this
patch is nowhere near `correct', in fact it is rubbish.
It half reverts a change which I made in December when there were problems
with CCID3. 
Can you please revert this patch - I will send an update shortly which 
restores the original state. Arnaldo got it right in the first place, the
patch used since December allows only stupid client/server applications,
and it is likely that it causes a bug (as reported on dccp@vger), although
I have been unable to reproduce the bug as reported.

Sorry again for the inconvenience.

Gerrit

Quoting Arnaldo Carvalho de Melo:
|  This fixes a bug caused by a previous patch, which causes DCCP servers in
|  LISTEN state to not receive packets.
|  
|  This patch changes the logic so that
|   * servers in either LISTEN or OPEN state get the RX half connection packets
|   * clients in OPEN state get the TX half connection packets
|  
|  Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
|  
