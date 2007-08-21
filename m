From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 21 Aug 2007 19:44:20 +0000
Subject: Re: [PATCH 2/3]: Provide 10s of microsecond timesource
Message-Id: <20070821194420.GI10392@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200708212000.16659@strip-the-willow>
In-Reply-To: <200708212000.16659@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Aug 21, 2007 at 08:00:16PM +0100, Gerrit Renker escreveu:
> [DCCP]: Provide 10s of microsecond timesource
> 
> This provides a timesource, conveniently used for DCCP timestamps, which 
> returns the elapsed time in 10s of microseconds since initialisation. 
> This makes for a wrap-around time of about 11.9 hours, which should be
> sufficient for most applications.

Why do it at kernel boot (or at dccp module load time to be more
precise)? Why not do it at sock creation time? Then it will be 11.9
hours after the socket is created.

This is how dccps_epoch was used BTW :-)

- Arnaldo
