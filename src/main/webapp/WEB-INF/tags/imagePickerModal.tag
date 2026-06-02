<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>

<div id="imagePickerModal"
     class="hidden fixed inset-0 z-[60] items-center justify-center bg-black/50 p-4"
     role="dialog" aria-modal="true" aria-labelledby="imagePickerTitle" aria-hidden="true">
    <div class="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-xl"
         data-image-picker-stop>

        <div data-image-picker-view="picker">
            <div class="px-6 py-5 border-b border-gray-100">
                <h3 id="imagePickerTitle" class="text-base font-bold text-gray-900">ছবি যোগ করুন</h3>
                <p class="mt-1 text-xs text-gray-500">আপনি কীভাবে ছবি যোগ করতে চান?</p>
            </div>
            <div class="p-4 grid grid-cols-2 gap-3">
                <button type="button" data-image-picker-action="camera"
                        class="flex flex-col items-center gap-2 rounded-xl border border-gray-200 hover:border-brand hover:bg-brand/5 active:bg-brand/10 px-4 py-5 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                    <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-brand/10 text-brand [&>svg]:w-6 [&>svg]:h-6">
                        <my:icon name="camera"/>
                    </span>
                    <span class="text-sm font-semibold text-gray-900">ক্যামেরা</span>
                    <span class="text-xs text-gray-500">ছবি তুলুন</span>
                </button>
                <button type="button" data-image-picker-action="file"
                        class="flex flex-col items-center gap-2 rounded-xl border border-gray-200 hover:border-brand hover:bg-brand/5 active:bg-brand/10 px-4 py-5 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                    <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-brand/10 text-brand [&>svg]:w-6 [&>svg]:h-6">
                        <my:icon name="upload"/>
                    </span>
                    <span class="text-sm font-semibold text-gray-900">গ্যালারি</span>
                    <span class="text-xs text-gray-500">ডিভাইস থেকে</span>
                </button>
            </div>
            <div class="px-4 pb-4">
                <button type="button" data-image-picker-action="cancel"
                        class="w-full inline-flex items-center justify-center rounded-md border border-gray-200 bg-white text-gray-700 px-4 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                    বাতিল
                </button>
            </div>
        </div>

        <div data-image-picker-view="capture" class="hidden">
            <div class="px-4 py-3 border-b border-gray-100 flex items-center gap-2">
                <button type="button" data-image-picker-action="back"
                        class="inline-flex items-center justify-center w-9 h-9 rounded-md text-gray-500 hover:bg-gray-100 transition"
                        aria-label="ফিরে যান">
                    <my:icon name="arrowLeft"/>
                </button>
                <h3 class="text-base font-bold text-gray-900">ক্যামেরা</h3>
            </div>

            <div class="bg-black aspect-[4/3] flex items-center justify-center overflow-hidden relative">
                <video data-image-picker-video autoplay playsinline muted
                       class="w-full h-full object-cover"></video>
                <div data-image-picker-status
                     class="hidden absolute inset-0 flex items-center justify-center bg-gray-900 text-white text-sm text-center px-4">
                    <span data-image-picker-status-text>ক্যামেরা চালু করা হচ্ছে…</span>
                </div>
            </div>

            <div class="p-4 flex items-center justify-between gap-3">
                <button type="button" data-image-picker-action="cancel"
                        class="rounded-md border border-gray-200 bg-white text-gray-700 px-4 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                    বাতিল
                </button>
                <button type="button" data-image-picker-action="snap"
                        class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40 disabled:opacity-50 disabled:cursor-not-allowed"
                        data-image-picker-snap disabled>
                    <my:icon name="camera"/>
                    <span>ছবি তুলুন</span>
                </button>
            </div>
            <canvas data-image-picker-canvas class="hidden"></canvas>
        </div>
    </div>
</div>
