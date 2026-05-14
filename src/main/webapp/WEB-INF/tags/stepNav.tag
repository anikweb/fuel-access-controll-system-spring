<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="prevHref" required="true" %>
<%@ attribute name="primaryLabel" required="true" %>

<div class="flex items-center justify-between pt-2 gap-3">
    <a href="${prevHref}" class="inline-flex items-center gap-1.5 text-sm font-medium text-gray-700 hover:text-gray-900">
        <span class="[&>svg]:w-4 [&>svg]:h-4"><my:icon name="arrowLeft"/></span>
        পিছনে যান
    </a>
    <div class="w-44">
        <my:button label="${primaryLabel}" type="submit" variant="primary" trailingIcon="arrow"/>
    </div>
</div>
