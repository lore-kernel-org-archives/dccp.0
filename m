From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 11:03:02 +0000
Subject: Re: [BUG] CCID3 no longer works!
Message-Id: <200611301103.02948@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
In-Reply-To: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
|  sent
It seems that the receiver does not get into the state NO_FBACK, since this
message is printed only in the state TFRC_SSTATE_NO_SENT, which indicates that
the state transmission TFRC_SSTATE_NO_SENT --> TFRC_SSTATE_NO_FBACK is not
performed as it should be.
Helpful to have this comment - previously the code just ignored this case.
I will try and find the cause, it would be good to have more information.

Thanks
Gerrit
