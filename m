From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Mon, 04 Dec 2006 08:11:49 +0000
Subject: Re: [BUG] CCID3 performance
Message-Id: <20061204081149.GB63326@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
In-Reply-To: <5640c7e00612031755h434e643cwf87e043a8ec0d163@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Dec 04, 2006 at 07:15:58AM +0000, Gerrit Renker wrote:
> the top performance even with CCID2 is 15Mbits/sec.

CCID2 used to be 1gbit/s in august with my "performance" patches, now commited.
I ran on an intel xeon 3ghz i think, with PCIe and e1000 gbit cards.  It's
stopped being gbit/s around september I think, towards the time that the TX
buffering stuff + some other was introduced.  This doesn't mean that those
patches are ``problematic'' but rather that something in the kernel changed
around that time... maybe even other random code.  I don't know what the deal is
now.

I highly suggest the use of oprofile in case you aren't using it yet.  To
relieve CPU usage:
* boot parameter:  clock=tsc
* the most expensive thing should be checksum calculating [~25%].  If it's not,
  then something fucked up in DCCP.
* After checksum calculation, the profile should be flat.  That is, 100000
  functions, each taking 0.1%.

Regarding checksums, have a look at:
http://darkircop.org/check.png
Different hardware has different checksum calculation capabailities [same
checksum code in user-land [i386 code]] =D.  We need to offload to the NIC at
some point and see if we can gain that extra speed.  Also, partial checksums in
DCCP will help a lot [cf. TCP].
