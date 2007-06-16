From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 16 Jun 2007 14:44:05 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <200706161544.05430@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > The name was chosen for consistency with timeval_delta(), which is the current
|  > function for microsecond time differences in net/dccp/dccp.h.
|  
|  I'm going to rename ktime_delta() to ktime_us_delta(), as it receives
|  two ktime_t values, but returns a delta in microseconds, not in
|  ktime_t.
I am going to change that in my tree as well, since I am busy updating with regard
to most recent changes anyway.
