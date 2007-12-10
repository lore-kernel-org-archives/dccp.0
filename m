From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Dec 2007 10:56:17 +0000
Subject: Re: [PATCH 2/8] [TFRC]: Put RX/TX initialisation into tfrc.c
Message-Id: <20071210105617.GA4688@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This separates RX/TX initialisation and puts all packet history / loss intervals
| > initialisation into tfrc.c.
| > The organisation is uniform: slab declaration -> {rx,tx}_init() -> {rx,tx}_exit()
| 
| NAK, you can't call a __exit marked routine from a __init marked
| routine.
| 
Ok thanks, will fix that in revision 2.
