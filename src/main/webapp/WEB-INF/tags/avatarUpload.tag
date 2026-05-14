<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="initial" required="false" %>

<div class="relative inline-block" data-avatar-root>
    <span class="relative block w-24 h-24 rounded-full overflow-hidden bg-gray-100 ring-2 ring-gray-200">
        <img src="${initial}"
             alt="Avatar"
             class="w-full h-full object-cover ${empty initial ? 'hidden' : ''}"
             data-avatar-img/>
        <span class="absolute inset-0 flex items-center justify-center text-gray-400 [&>svg]:w-12 [&>svg]:h-12 ${not empty initial ? 'hidden' : ''}"
              data-avatar-fallback>
            <my:icon name="user"/>
        </span>
    </span>
    <label for="${id}"
           class="absolute bottom-0 right-0 inline-flex items-center justify-center w-8 h-8 rounded-full bg-brand text-white cursor-pointer ring-2 ring-white transition hover:bg-brand-700">
        <span><my:icon name="camera"/></span>
    </label>
    <input id="${id}" name="${name}" type="file" accept="image/*"
           class="sr-only" data-avatar-input/>
</div>
