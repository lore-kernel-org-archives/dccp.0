From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Jun 2011 08:19:18 +0000
Subject: Re: Doubt about DCCP_SOCKOPT_GET_CUR_MPS
Message-Id: <20110613081918.GD5601@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <BANLkTikMe4KHb1tDvb7_XCsvwsLvvqN=1w@mail.gmail.com>
In-Reply-To: <BANLkTikMe4KHb1tDvb7_XCsvwsLvvqN=1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Hi guys, I'm dealing with a doubt to retrieve the current PMTU. I'm
| calling the getsockopt syscall with DCCP_SOCKOPT_GET_CUR_MPS option. I
| tried such operation in both sides with the socket opened. however,
| I'm always getting the same value: 0.  I'm running this in loopback
| interface.
|      Is that right for such network interface?
| 
I remember that it used to work and would return an MPS of about 16k.
A value of 0 is strange here, even if uninitialized it should at least
return a value around 536 = TCP_MSS_DEFAULT. Need to check.
