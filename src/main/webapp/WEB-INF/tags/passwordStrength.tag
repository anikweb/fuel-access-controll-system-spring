<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="targetId" required="true" %>

<div data-strength-meter data-target="${targetId}">
    <div class="flex items-center justify-between text-xs">
        <span class="text-gray-500">পাসওয়ার্ডের শক্তি</span>
        <span class="font-medium
                     data-[strength=0]:text-gray-400
                     data-[strength=1]:text-red-600
                     data-[strength=2]:text-amber-600
                     data-[strength=3]:text-lime-700
                     data-[strength=4]:text-brand"
              data-strength="0"
              data-strength-label></span>
    </div>
    <div class="mt-1 h-1 rounded-full bg-gray-200 overflow-hidden">
        <div class="h-full transition-all duration-300
                    data-[strength=0]:w-0
                    data-[strength=1]:w-1/4 data-[strength=1]:bg-red-500
                    data-[strength=2]:w-1/2 data-[strength=2]:bg-amber-500
                    data-[strength=3]:w-3/4 data-[strength=3]:bg-lime-500
                    data-[strength=4]:w-full data-[strength=4]:bg-brand"
             data-strength="0"
             data-strength-bar></div>
    </div>
    <p class="mt-2 flex items-start gap-1.5 text-xs text-gray-500">
        <span class="text-gray-400 mt-px shrink-0 [&>svg]:w-3.5 [&>svg]:h-3.5"><my:icon name="info"/></span>
        <span>পাসওয়ার্ডে অন্তত ৮টি অক্ষর, একটি সংখ্যা এবং একটি বিশেষ চিহ্ন ব্যবহার করুন।</span>
    </p>
</div>
