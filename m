From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 23 Aug 2007 15:35:42 +0000
Subject: Re: [PATCHv2  2/3]: Provide 10s of microsecond timesource
Message-Id: <20070823153542.GI23220@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200708231610.08471@strip-the-willow>
In-Reply-To: <200708231610.08471@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 23, 2007 at 04:10:08PM +0100, Gerrit Renker escreveu:
> I have thought this over - the solutions I came up with were all complicated
> and I think it is not worth making it more complicated if the issue only occurs
> every 11.9 hours. But added a warning note in the timer comments, so that other
> timestamp users may take preventive action, if necessary.

Seems OK, I'm busy ATM but promise will test this and provide comments
in time for 2.6.24.

Thanks for your work, Gerrit, keep it up!

- Arnaldo
