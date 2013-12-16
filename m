From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Dec 2013 22:27:23 +0000
Subject: Re: [PATCH net-next 10/10] dccp: remove unused code
Message-Id: <20131216152723.07d7a7aa@liptov.cs.ualberta.ca>
List-Id: <dccp.vger.kernel.org>
References: <20131216113943.4d9e9eae@nehalam.linuxnetplumber.net>
In-Reply-To: <20131216113943.4d9e9eae@nehalam.linuxnetplumber.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

(We had left it in there since the spec defines the option in RFC 4340, 13.2,
 but there had so far not been any need to use it.)

> This function is defined but not used.
> Remove it now, can come back when used.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
