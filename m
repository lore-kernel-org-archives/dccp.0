From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 01 Mar 2011 12:16:21 +0000
Subject: Re: dccp: null-pointer dereference on close
Message-Id: <20110301121621.GB3567@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20110226174505.GB3609@localhost>
In-Reply-To: <20110226174505.GB3609@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Below are the bits that fixed the issue on 2.6.37. Perhaps this along
| with a more detailed description of the error, including the panic
| message, could serve as the basis for such a patch?
| 
Yes, thank you for the suggestion. I will incorporate your suggestions and submit the
reworked patch first thing tomorrow morning, need to go through the original also.
