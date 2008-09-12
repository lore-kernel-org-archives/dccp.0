From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Sep 2008 05:16:12 +0000
Subject: Re: What to do with DCCP
Message-Id: <20080912051612.GB3506@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080910.225311.160279498.davem@davemloft.net>
In-Reply-To: <20080910.225311.160279498.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| But as networking maintainer I do have a right to put my foot down when
| something all the build testers are going to try is going to send out
| a bogus warning that helps nobody with anything.
| 
Which is entirely correct -- that part is really not suitable for
consideration in mainline. There are several such duct-tape measures
in the test tree, which will have to wait until there is enough time
to fix each of the causes and test the replaced code.

There are problems of the mainline DCCP variant which are fixed in the
test tree, but until everything has been resolved will take some time.
