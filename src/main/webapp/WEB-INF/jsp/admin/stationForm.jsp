<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="নতুন স্টেশন | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন" active="true"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/admin/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <my:formCard
            title="নতুন স্টেশন যোগ করুন"
            subtitle="সিস্টেমে নতুন ফুয়েল স্টেশনের তথ্য যুক্ত করুন।"
            sectionTitle="স্টেশনের পরিচিতি"
            action="/admin/stations"
            cancelHref="/admin/stations">

            <my:input id="name" name="name" type="text"
                      label="স্টেশন নাম" required="true"
                      leadingIcon="terminal"
                      placeholder="স্টেশনের নাম লিখুন"
                      autocomplete="off"
                      value="${station.name}"
                      error="${errors['name']}"/>

            <my:textarea id="location" name="location"
                         label="ঠিকানা" required="true"
                         leadingIcon="mapPin"
                         placeholder="বিস্তারিত ঠিকানা লিখুন"
                         rows="4"
                         value="${station.location}"
                         error="${errors['location']}"/>

        </my:formCard>
    </jsp:body>

</my:panelLayout>
