From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 03 Dec 2006 15:30:20 +0000
Subject: Re: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <20061203153019.GK10303@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.01580@strip-the-willow>
In-Reply-To: <200612011827.01580@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sun, Dec 03, 2006 at 03:26:20PM +0000, Gerrit Renker wrote:
> Quoting Ian McDonald:
> |  The
> |  reason I say this is good as in the back of my mind I am thinking of
> |  people looking for DoS vulnerabilities...
> |  
> |  However BUG_ON does work and forces the code to get tidied so the
> |  condition doesn't occur again. So whichever way I'm happy to go ahead
> |  with it.
> What you are saying is very important and I suggest auditing the code against
> calling this function with invalid parameters as next to-do.
> 
> I would further like to inform you and Arnaldo that I have ironed out an error
> of mine in this patch (uploaded), namely the following

Heh, I was _just_ hitting enter to commit exactly this patch, so lemme
get the_whole_lot again to get this one, thanks a lot!

- Arnaldo
