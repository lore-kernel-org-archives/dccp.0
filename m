From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 21:00:30 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611282100.30498@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  Why is it broken? The RFC says that the user can have the option of
|  setting the packet size s, so it is not experimental. Yes it is only
|  for CCID3 but there are already lots of things that are CCID2 or CCID3
|  only.
... and that is the problem I am referring to. From the local perspective of adding
    this or that socket option, nothing is probably too much of a burden. But there
    is no documentation for these socket options (I have at begun with documenting some
    sysctls). Hence one can not, with a good conscience, argue that the programming interface
    is `as easy as UDP'. I think that should be the guideline and that is what I am proposing,
    leave everything out which is not strictly and essentially requrired. Otherwise, it will
    confuse users. 
    I had meant for a long time to put up my updated ttcp clone but I will put nothing online
    until the socket API is not ironed out and documented. 
    And there are some credits to be had for people daring enough to document the socket API -
    the DCCP user guide is apparently well well out of date.

In short: my suggestion is to keep an experimental patch for this and I would even offer to
          keep one up-to-date and online, if in return we can simplify the socket API. Does 
          this sound like a more convincing argument?

Gerrit
