From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 07:37:42 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <200708210837.42407@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  At least mine are working again, but versions are very unstable at the
|  moment. For example one machine won't run on a 2.6.22 Debian kernel at
|  the moment...
I was using the 2.6.24 netdev tree and it produced an oops for the e100 card;
hung when it tried to re-initialise the serial consoles; on a double Xeon PIII
will not boot; on the laptop there is apparently the ACPI problem again.

|  > The test tree was synchronised yesterday against davem-2.6
|  
|  2.6 or 2.6.24?? I thought Arnaldo's changes went into 24...
Oh no, yesterday it was 2.6.23-rc2/3 without Arnaldo's changes. 

In any case, I shall from now on put known-to-work test-tree patches per-kernel-version on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/

The test tree is now resynched to match Arnaldo's set, but I need a separate email to
list the changes.
