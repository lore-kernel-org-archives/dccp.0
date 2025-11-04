Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com [209.85.128.68])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B858D340A7D
	for <dccp@vger.kernel.org>; Tue,  4 Nov 2025 18:12:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.68
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1762279941; cv=none; b=CL5aLtDvOrrpi5IrF0PoEIwuQNt5vH/hP+HOeaq9nMQpSimQTytxK3wNhKh0jcIxDX3FZudlVmB2TKy62Cg2ZniSOAJeeao5KGq+hKlPUE/TawTtWeWi7AR0iQYc4w9rCnXiuB6b7TbYFIFA2fgCMdqRU7eMSyMVomwjfJncSOQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1762279941; c=relaxed/simple;
	bh=pShB2wGmw9UVAjvo4Af9ENCGF7h74zxwzh2zJGAYYVY=;
	h=Content-Type:From:To:Subject:Message-ID:Date:MIME-Version; b=JJ1nsK7ojpzuTYfFagySBeYD4n/ZGbq2MAWaHb4QVZlxqtLi6jKvd3qfLAu3KaO/6gUGOorNIAOAvw18slownufExDWBy8bwo1Edc+ZcdPKCp7B5A/OILlY5v2XMyH/8TCbhT14lodOoZ+aNbz28nBkaRlRdTH1TYcprC3YVyc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TFnIQq5M; arc=none smtp.client-ip=209.85.128.68
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TFnIQq5M"
Received: by mail-wm1-f68.google.com with SMTP id 5b1f17b1804b1-477563bcaacso7283985e9.1
        for <dccp@vger.kernel.org>; Tue, 04 Nov 2025 10:12:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1762279938; x=1762884738; darn=vger.kernel.org;
        h=mime-version:date:content-transfer-encoding:message-id:subject
         :reply-to:to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=pShB2wGmw9UVAjvo4Af9ENCGF7h74zxwzh2zJGAYYVY=;
        b=TFnIQq5MDU3ufslHq+yEcFttra9Lv+QP8a0q5tVBzIOd9G9C8IbJVOFjyoDralmiUd
         5Qoaqz4FJpHACH2NevNIvQ/FuO2fU7tQ/Id5mYIxbgwjVUXynOddN0FgKsyr1j3tIMSG
         BpJVs7umAkYt4agkZ6UQy58cOvhCTT+0F1mAOzGIJ/dNQ6fHsQMD3+3BeTcm2tI9tEii
         BJJsbtB3Pyy9ZJGe3/HMZBya+jplfddPQrh9xshQRlX5pXyGjggY0sv1jLNgll/OTj0D
         lAubqlkDoYEqy/jjBiVRpvaENu7W32m2xBL3Uc92S22RwBQz2qYOf8FwRd2PjNO9WH3v
         9Ftw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1762279938; x=1762884738;
        h=mime-version:date:content-transfer-encoding:message-id:subject
         :reply-to:to:from:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=pShB2wGmw9UVAjvo4Af9ENCGF7h74zxwzh2zJGAYYVY=;
        b=CPBRMHRImFLOxhLM6xxVpmC7nrW9x9CkauRtHcs0y7xSYfDxwNzllodGNYK0n5LWEI
         yZdh1UkB7QIdMhEjkOM+lH5QL3IMosJ6Hken7omKZhEJrhAQNGjsFpFF1U1cIsYfY20g
         Lf2/Uh6YzzGWOxCyLuLZ6urf4MDya75CW43NtOzUJV0UtmiH9qFpaK5k5xY7ERNoU10G
         WksRmv2pcRU9+X+A3vfQQVmyMUeZVLJ2+wNODutRhvm1VOIzD/jYj/Ns20KXXehBtZ9Q
         SaPaUz1jM0AdV5lfUrdvN3Cd8qtEeIYWsLlYEn/n3XxHDGPuAN87TciaKZUG2orWjL0l
         HzRQ==
X-Gm-Message-State: AOJu0YzOhDYdaV2oJy5+LGP2NTHnFdFJntqsPrnJ2gkjwjIiF7eJhXiz
	CWbwnNjnZcGo7q5Afvg/AROo5S3fVKhRbCg9G3k69UcI7DfBTzvc+y1jS9Gj9sBn
X-Gm-Gg: ASbGnctYF71gJ6YfRBAE5nn+34qxzRuvJpcYu70mpHRK+VvJ4MjVWQy7Rh4096Xeg68
	l1KXL3NwkpcGna7XkpU5I/oLnUGWbpth518XVc85LVe2Fbgia4MEkC9migCT7vcx/0RXdZ3sexT
	D+Yl50igl+Fg4fQRnre6BvCMNeWDaHt9tidRg3Zz5YcHiNIqGfz0F83T6EyBohG8WJg2e2y5rdU
	UYyrGp2iJTl/ZRWvcFaSLYjyqGa70zORI3UDFCnfSVO9Ya5q2GNn1smvI2TayuywcKAk2HUjs5t
	ljKKm2cFW2HgNgPWPg9Vj9Nrz+xPrMZBkA7P4Pv7BJ2i4ceyXMxRwHkZCV59ejNUyK9/n1WsvEU
	mIwsi0Cgy3PESYs8N7CPbGfrt2g0hQYkUejpD0ob1ZhV+XdmtQ82KFXS5OlTuRrdUXxguK4u/C+
	v90sCqVznY7h3TuX/Hu0nxeGqh
X-Google-Smtp-Source: AGHT+IFLPSuOYw9ICfoBOSZVWUom/BY59G2TKqFdqznFiS1m9YaXAWrLZVVkefQbgxUGYF7gAolnGA==
X-Received: by 2002:a05:600c:a00b:b0:477:5c35:39bf with SMTP id 5b1f17b1804b1-4775ce81932mr1980725e9.35.1762279937346;
        Tue, 04 Nov 2025 10:12:17 -0800 (PST)
Received: from [127.0.0.1] ([154.80.6.21])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4775cdcc552sm2610835e9.6.2025.11.04.10.12.12
        for <dccp@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 04 Nov 2025 10:12:16 -0800 (PST)
Content-Type: text/plain; charset=utf-8
From: Carl Thomas <liam.intelservices80@gmail.com>
To: dccp@vger.kernel.org
Reply-To: carlthomasces@gmail.com
Subject: Estimating & Takeoff Services
Message-ID: <673af14e-87ef-e694-8f70-5a23d8193884@gmail.com>
Content-Transfer-Encoding: quoted-printable
Date: Tue, 04 Nov 2025 18:12:11 +0000
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi,

Are you looking to estimate your projects?

We offer construction =
estimating services and quantity takeoffs to contractors, sub-contractors, =
developers, architects, etc.

Get accurate takeoffs at competitive rates =
with a quick turnaround and win more bids. Thanks.

Regards,
Carl Thomas
Marketing Executive
City Estimating, LLC
