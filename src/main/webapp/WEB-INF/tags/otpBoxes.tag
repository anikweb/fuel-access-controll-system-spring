<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="length" required="false" %>

<c:set var="n" value="${empty length ? 6 : length}"/>
<div class="flex justify-center gap-2 sm:gap-3" data-otp-group>
    <c:forEach begin="1" end="${n}" varStatus="status">
        <input type="text"
               inputmode="numeric"
               pattern="[0-9]*"
               maxlength="1"
               autocomplete="${status.index == 0 ? 'one-time-code' : 'off'}"
               class="w-12 h-12 sm:w-14 sm:h-14 text-center text-xl font-semibold text-gray-900 rounded-lg border border-gray-300 bg-white focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/20"
               aria-label="OTP digit"/>
    </c:forEach>
</div>
<input type="hidden" name="${name}" data-otp-output value=""/>
